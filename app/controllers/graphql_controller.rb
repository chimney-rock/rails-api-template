class GraphqlController < ActionController::API
  def index
    render json: 'Nothing to see here'
  end

  def execute
    query          = params[:query]
    variables      = ensure_hash(params[:variables])
    operation_name = params[:operationName]
    context = {}

    render json: Schema.execute(query, variables: variables, context: context, operation_name: operation_name)
  rescue => err
    raise err unless Rails.env.development?
    handle_error_in_development(err)
  end

  private

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def handle_error_in_development(err)
    Rails.logger.error(err.message)
    Rails.logger.error(err.backtrace.join("\n"))

    render json: {
      error: {
        message: err.message,
        backtrace: err.backtrace
      },
      data: {}
    }, status: 500
  end
end
