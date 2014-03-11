# Configure DataMapper - use in-memory connection
::DataMapper::Property::String.length(255)
::DataMapper::Property::Boolean.allow_nil(false)
::DataMapper::Model.raise_on_save_failure = true
::DataMapper.setup(:default, 'sqlite::memory:')

# Create the tables
::DataMapper.auto_migrate!
