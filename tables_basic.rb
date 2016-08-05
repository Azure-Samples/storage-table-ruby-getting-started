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

# Table Basic Samples
class TableBasicSamples
  def run_all_samples(client)
    table_service = Azure::Storage::Table::TableService.new(client: client)

    puts "\n\n* Basic table operations *\n"
    basic_table_operations(table_service)

    puts "\n\nAzure Table samples - Completed"

  rescue Azure::Core::Http::HTTPError => ex
    if AzureConfig::IS_EMULATED
      puts 'Error occurred in the sample. If you are using the emulator, '\
      "please make sure the emulator is running. #{ex}"
    else
      puts 'Error occurred in the sample. Please make sure the account name'\
      " and key are correct. #{ex}"
    end
  end

  def basic_table_operations(table_service)
    table_name = 'tablesample' + RandomString.random_name

    # Create a new table
    puts "Create a table with name #{table_name}"

    table_service.create_table(table_name)

    # Create a sample entity to insert into the table
    customer = { 'PartitionKey' => 'Harp', 'RowKey' => '1',
                 'email' => 'harp@contoso.com', 'phone' => '555-555-5555' }

    # Insert the entity into the table
    puts "Insert a new entity into table #{table_name}"
    table_service.insert_entity(table_name, customer)

    puts 'Successfully inserted the new entity'

    # Demonstrate how to query the entity
    puts 'Read the inserted entity'
    read_customer = table_service.get_entity(table_name, 'Harp', '1')
    puts read_customer.properties['email']
    puts read_customer.properties['phone']

    # Demonstrate how to update the entity by changing the phone number
    puts 'Update an existing entity by changing the phone number'
    customer = { 'PartitionKey' => 'Harp', 'RowKey' => '1',
                 'phone' => '425-123-1234' }
    table_service.update_entity(table_name, customer)

    # Demonstrate how to query the updated entity, filter the results with a
    # filter query and select only the value in the phone column
    puts 'Read the updated entity with a filter query'
    entities = table_service.query_entities(table_name,
                                            filter: "PartitionKey eq 'Harp'",
                                            select: ['phone'])
    entities.each do |entity|
      puts entity.properties['phone']
    end

    # Demonstrate how to delete an entity
    puts 'Delete the entity'
    table_service.delete_entity(table_name, 'Harp', '1')

    puts 'Successfully deleted the entity'

    # Demonstrate deleting the table, if you don't want to have the table
    # deleted comment the below block of code
    puts 'Delete the table'
    table_service.delete_table(table_name)

    puts 'Successfully deleted the table'
  end
end
