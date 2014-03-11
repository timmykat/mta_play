require 'yaml'

# Get configuration
$config = YAML::load(File.open('config.yml'))

# The following creates a charge lookup table based on (rider type, transport type, and method - pass or charge
$fee_lookup = {}
$config['rider'].each do |k, v|
  $fee_lookup[k] = {}
  $config['transport'].each do |kk, vv|
    $fee_lookup[k][kk] = {
      'pass' => v['discount'].to_f * vv['pass'].to_f,
      'fee'  => v['discount'].to_f * vv['fee'].to_f
    }
  end
end

