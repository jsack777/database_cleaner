require 'database_cleaner/active_record/base'
require 'ruby-debug'

$logger ||= Logger.new("/tmp/activerecord.log")
ActiveRecord::Base.logger = $logger

module DatabaseCleaner::ActiveRecord
  class Savepoint
    include ::DatabaseCleaner::ActiveRecord::Base

    def start
      if connection_klass.connection.open_transactions == 0
        connection_klass.connection.begin_db_transaction
      end
      connection_klass.connection.create_savepoint

#debugger
      if connection_klass.connection.respond_to?(:increment_open_transactions)
        connection_klass.connection.increment_open_transactions
      else
        connection_klass.__send__(:increment_open_transactions)
      end
    end


    def clean
#debugger
      if connection_klass.connection.respond_to?(:decrement_open_transactions)
        connection_klass.connection.decrement_open_transactions
      else
        connection_klass.__send__(:decrement_open_transactions)
      end

      if connection_klass.connection.open_transactions >= 0
        connection_klass.connection.rollback_to_savepoint
        connection_klass.connection.release_savepoint
      end

      if connection_klass.connection.open_transactions == 0
        connection_klass.connection.rollback_db_transaction
      end
    end
  end
end
