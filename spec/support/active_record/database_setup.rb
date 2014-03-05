require 'yaml'

def db_config
  config_path = 'db/config.yml'
  @db_config ||= YAML.load(IO.read(config_path))
end
