require 'database_cleaner/active_record/base'
#require 'ruby-debug'

$logger ||= Logger.new("/tmp/activerecord.log")
ActiveRecord::Base.logger = $logger

module DatabaseCleaner::ActiveRecord
  class Savepoint
    include ::DatabaseCleaner::ActiveRecord::Base
    include ::DatabaseCleaner::Generic::Transaction

    def start
      if connection_class.connection.open_transactions == 0
        connection_class.connection.begin_db_transaction
      end
      connection_class.connection.create_savepoint

#debugger
      if connection_class.connection.respond_to?(:increment_open_transactions)
        connection_class.connection.increment_open_transactions
      else
        connection_class.__send__(:increment_open_transactions)
      end
    end


    def clean
#debugger
      if connection_class.connection.respond_to?(:decrement_open_transactions)
        connection_class.connection.decrement_open_transactions
      else
        connection_class.__send__(:decrement_open_transactions)
      end

      if connection_class.connection.open_transactions >= 0
        connection_class.connection.rollback_to_savepoint
        connection_class.connection.release_savepoint
      end

      if connection_class.connection.open_transactions == 0
        connection_class.connection.rollback_db_transaction
      end
    end
  end
end
