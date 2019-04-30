namespace :graphql do
  task :schema, [:output_path] => :environment do |t, args|
    args.with_defaults(output_path: Rails.root.join('public'))

    FileUtils.mkdir_p(File.dirname(args.output_path))

    definition_file = "#{args.output_path}/schema.graphql"
    File.open(definition_file, 'w') do |f|
      f.write(ApiSchema.to_definition)
    end
    puts "Wrote schema definition to `#{definition_file}`"

    json_file = "#{args.output_path}/schema.json"
    File.open(json_file, 'w') do |f|
      f.write(ApiSchema.execute(query: GraphQL::Introspection::INTROSPECTION_QUERY).to_json)
    end
    puts "Wrote schema JSON to `#{json_file}`"
  end
end
