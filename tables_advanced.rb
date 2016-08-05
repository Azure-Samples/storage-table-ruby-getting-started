#-------------------------------------------------------------------------------
# Microsoft Developer & Platform Evangelism
#
# Copyright (c) Microsoft Corporation. All rights reserved.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#-------------------------------------------------------------------------------
# The example companies, organizations, products, domain names,
# e-mail addresses, logos, people, places, and events depicted
# herein are fictitious.  No association with any real company,
# organization, product, domain name, email address, logo, person,
# places, or events is intended or should be inferred.
#-------------------------------------------------------------------------------

#
# Azure Table Service Sample - Demonstrate how to perform common tasks using the
# Microsoft Azure Table Service
# including creating a table, CRUD operations and different querying techniques.
#
# Documentation References:
#  - What is a Storage Account - http://azure.microsoft.com/en-us/documentation/articles/storage-whatis-account/
#  - Getting Started with Tables - https://azure.microsoft.com/en-us/documentation/articles/storage-ruby-how-to-use-table-storage/
#  - Table Service Concepts - http://msdn.microsoft.com/en-us/library/dd179463.aspx
#  - Table Service REST API - http://msdn.microsoft.com/en-us/library/dd179423.aspx
#  - Table Service Ruby API - http://azure.github.io/azure-storage-ruby/
#  - Storage Emulator - http://azure.microsoft.com/en-us/documentation/articles/storage-use-emulator/
#

require './random_string'

# Table Advanced Samples
class TableAdvancedSamples
  def run_all_samples(client)
    table_service = Azure::Storage::Table::TableService.new(client: client)

    puts "\n\n* List tables *\n"
    list_tables(table_service)

    puts "\n\n* Service Properties *\n"
    service_properties(table_service)

    puts "\n\n* Set CORS Rules *\n"
    cors_rules(table_service)

    puts "\n\n* Table Access Policy *\n"
    table_acl(table_service)

    puts "\n\nAzure Advanced Table samples - Completed"

  rescue Azure::Core::Http::HTTPError => ex
    if AzureConfig::IS_EMULATED
      puts 'Error occurred in the sample. If you are using the emulator, '\
      "please make sure the emulator is running. #{ex}"
    else
      puts 'Error occurred in the sample. Please make sure the account name'\
      " and key are correct. #{ex}"
    end
  end

  def list_tables(table_service)
    table_prefix = 'table' + RandomString.random_name

    # Create tables
    for i in 0..4
      table_name = table_prefix + i.to_s
      puts "Create a table with name #{table_name}"
      table_service.create_table(table_name)
    end

    # List all the tables
    puts 'List tables'
    tables = table_service.query_tables
    tables.each do |table|
      puts 'Table Name: ' + table[:properties]['TableName']
    end

    # Delete the tables
    puts "Delete Tables with prefix #{table_prefix}"
    for i in 0..4
      table_name = table_prefix + i.to_s
      table_service.delete_table(table_name)
    end

    puts 'List tables sample completed'
  end

  def service_properties(table_service)
    # get service properties
    puts 'Get Service Properties'

    original_properties = table_service.get_service_properties

    # set service properties
    puts 'Overwrite Service Properties'

    properties = Azure::Storage::Service::StorageServiceProperties.new
    properties.logging.delete = true
    properties.logging.read = true
    properties.logging.write = true
    properties.logging.retention_policy.enabled = true
    properties.logging.retention_policy.days = 10

    table_service.set_service_properties(properties)

    # reverting service properties back to the original ones
    puts 'Revert Service Properties back the original ones'
    table_service.set_service_properties(original_properties)

    puts 'Service Properties sample completed'
  end

  def cors_rules(table_service)
    # get service properties
    puts 'Get Service Properties'
    original_service_properties = table_service.get_service_properties

    # set CORS rules
    puts 'Overwrite Cors Rules'
    cors_rule = Azure::Storage::Service::CorsRule.new
    cors_rule.allowed_origins = ['*']
    cors_rule.allowed_methods = %w(POST GET)
    cors_rule.allowed_headers = ['*']
    cors_rule.exposed_headers = ['*']
    cors_rule.max_age_in_seconds = 3600

    service_properties = Azure::Storage::Service::StorageServiceProperties.new
    service_properties.cors.cors_rules = [cors_rule]

    table_service.set_service_properties(service_properties)

    puts 'Revert Cors Rules back the original ones'
    table_service.set_service_properties(original_service_properties)

    puts 'CORS sample completed'
  end

  def table_acl(table_service)
    # Create table
    table_name = 'table' + RandomString.random_name
    puts "Create a table with name #{table_name}"
    table_service.create_table(table_name)

    # Set table acl
    puts 'Set table access policy'
    identifier = Azure::Storage::Service::SignedIdentifier.new
    identifier.id = 'MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI='
    identifier.access_policy = Azure::Storage::Service::AccessPolicy.new
    identifier.access_policy.start = '2009-09-28T08:49:37.0000000Z'
    identifier.access_policy.expiry = '2009-09-29T08:49:37.0000000Z'
    identifier.access_policy.permission = 'raud'

    table_service.set_table_acl(table_name, signed_identifiers: [identifier])

    # Get table acl
    puts 'Get table access policy'
    result = table_service.get_table_acl(table_name)
    puts 'Id: ' + result[0].id
    puts "Access Policy:\n"
    puts 'Start date: ' + result[0].access_policy.start + "\n"
    puts 'Expiry date: ' + result[0].access_policy.expiry + "\n"
    puts 'Permission: ' + result[0].access_policy.permission + "\n"

    # Delete the table
    puts 'Delete Table'
    table_service.delete_table(table_name)

    puts 'Table access policy sample completed'
  end
end
