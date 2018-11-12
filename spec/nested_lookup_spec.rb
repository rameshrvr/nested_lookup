require_relative '../lib/nested_lookup'

RSpec.describe NestedLookup do
  before(:all) do
    # Source documents
    @test_hash1 = { "a": 1, "b": { "d": 100 }, "c": { "d": 200 } }
    @test_hash2 = {
      "build_version": {
        "model_name": 'MacBook Pro',
        "build_version": {
          "processor_name": 'Intel Core i7',
          "processor_speed": '2.7 GHz',
          "core_details": {
            "build_version": '4',
            "l2_cache(per_core)": '256 KB'
          }
        },
        "number_of_cores": '4',
        "memory": '256 KB'
      },
      "os_details": {
        "product_version": '10.13.6',
        "build_version": '17G65'
      },
      "name": 'Test',
      "date": 'YYYY-MM-DD HH:MM:SS'
    }

    # Result documents
    @result_array1 = [
      {
        model_name: 'MacBook Pro',
        build_version: {
          processor_name: 'Intel Core i7',
          processor_speed: '2.7 GHz',
          core_details: {
            build_version: '4',
            "l2_cache(per_core)": '256 KB'
          }
        },
        number_of_cores: '4',
        memory: '256 KB'
      },
      {
        processor_name: 'Intel Core i7',
        processor_speed: '2.7 GHz',
        core_details: {
          build_version: '4',
          "l2_cache(per_core)": '256 KB'
        }
      },
      '4',
      '17G65'
    ]
  end

  it '1. Has a version number' do
    expect(NestedLookup::VERSION).not_to be nil
  end

  context '#Test1 - Feature nested_lookup' do
    context 'I. Verification for simple nested document (depth 2)' do
      it '1. Verify result for key (d)' do
        expect(@test_hash1.nested_lookup('d')).to eq [100, 200]
      end

      it '2. Verify return value is an Array' do
        expect(@test_hash1.nested_lookup('a')).to be_instance_of Array
      end

      it '3. Verify ErrorClass when no argument is passed' do
        expect { @test_hash1.nested_lookup }.to raise_error(ArgumentError)
      end

      it '4. Verify result for Array of Hashes' do
        expect([{}, @test_hash1, []].nested_lookup('d')).to eq [100, 200]
      end

      it '5. Verify result for wrapped Hashesin Array' do
        expect([{}, { 'e' => @test_hash1 }].nested_lookup('d')).to eq [100, 200]
      end

      it '6. Verify with_keys option returns Hash' do
        expect(@test_hash1.nested_lookup(
                 'd', with_keys: true
        )).to be_instance_of Hash
      end
    end

    context 'II. Verification for complex nested document (depth 4)' do
      it '1. Verify result for passed key (args - build_version)' do
        expect(@test_hash2.nested_lookup('build_version')).to eq(@result_array1)
      end

      it '2. Verify result for passed key (args - processor_speed)' do
        expect(@test_hash2.nested_lookup('processor_speed')).to eq ['2.7 GHz']
      end

      it '3. Verify wild option for argument (version)' do
        expected_result = @result_array1.insert(3, '10.13.6')
        expect(@test_hash2.nested_lookup(
                 'version', wild: true
        )).to eq expected_result
        @result_array1.delete_at(3)
      end

      it '4. Verify with_keys options for argument (build_version)' do
        expected_result = { 'build_version' => @result_array1 }
        expect(@test_hash2.nested_lookup(
                 'build_version', with_keys: true
        )).to eq expected_result
      end

      it '5. Verify wild, with_keys options for argument (version)' do
        expected_result = {
          'build_version' => @result_array1,
          'product_version' => ['10.13.6']
        }
        expect(@test_hash2.nested_lookup(
                 'version', wild: true, with_keys: true
        )).to eq expected_result
      end
    end
  end

  context '#Test2 - Feature get_all_keys' do
    it '1. Result should be an Array' do
      sample_data = { 'a': 'b', 'c': 'd' }
      expect(sample_data.get_all_keys).to be_instance_of Array
    end

    it '2. Verification for first sample data' do
      sample_data1 = {
        "hardware_details": {
          "model_name": 'MacBook Pro',
          "processor_details": {
            "processor_name": 'Intel Core i7',
            "processor_speed": '2.7 GHz',
            "core_details": {
              "total_numberof_cores": '4',
              "l2_cache(per_core)": '256 KB'
            }
          },
          "total_number_of_cores": '4',
          "memory": '16 GB'
        },
        "os_details": {
          "product_version": '10.13.6', "build_version": '17G65'
        },
        "name": 'Test',
        "date": 'YYYY-MM-DD HH:MM:SS'
      }
      keys_to_verify = [
        'model_name', 'core_details',
        'l2_cache(per_core)', 'build_version', 'date'
      ]
      result = sample_data1.get_all_keys
      expect(result.size).to eq(15)
      keys_to_verify.each do |key|
        expect(result).to include key
      end
      another_sample_data = [{}, sample_data1, {}]
      result2 = another_sample_data.get_all_keys
      expect(result2.size).to eq(15)
      keys_to_verify.each do |key|
        expect(result2).to include key
      end
    end

    it '3. Verification for second sample data' do
      sample_data2 = {
        "hardware_details": {
          "model_name": 'MacBook Pro',
          "processor_details": [
            {
              "processor_name": 'Intel Core i7',
              "processor_speed": '2.7 GHz',
              "core_details": {
                "total_numberof_cores": '4',
                "l2_cache(per_core)": '256 KB'
              }
            }
          ],
          "total_number_of_cores": '4',
          "memory": '16 GB'
        }
      }
      keys_to_verify = %w[hardware_details processor_speed
                          total_numberof_cores memory]
      result = sample_data2.get_all_keys
      expect(result.size).to eq(10)
      keys_to_verify.each do |key|
        expect(result).to include key
      end
    end

    it '4. Verification for third sample data' do
      sample_data3 = {
        "hardware_details": {
          "model_name": 'MacBook Pro',
          "processor_details": [
            {
              "processor_name": 'Intel Core i7',
              "processor_speed": '2.7 GHz'
            },
            {
              "total_numberof_cores": '4',
              "l2_cache(per_core)": '256 KB'
            }
          ],
          "total_number_of_cores": '4',
          "memory": '16 GB'
        }
      }
      keys_to_verify = ['processor_details', 'processor_name',
                        'l2_cache(per_core)', 'total_number_of_cores']
      result = sample_data3.get_all_keys
      expect(result.size).to eq(9)
      keys_to_verify.each do |key|
        expect(result).to include key
      end
    end
  end

  context '#Test3 - Feature get_occurrence' do
    it '1. Result should be FixNum' do
      sample_data = { 'a': 'b', 'c': 'd' }
      expect(sample_data.get_occurrence_of_key('a')).to be_instance_of Fixnum
      expect(sample_data.get_occurrence_of_value('d')).to be_instance_of Fixnum
    end

    it '2. Verification for first sample data' do
      sample_data1 = {
        "build_version": {
          "model_name": 'MacBook Pro',
          "build_version": {
            "processor_name": 'Intel Core i7',
            "processor_speed": '2.7 GHz',
            "core_details": { "build_version": '4',
                              "l2_cache(per_core)": '256 KB' }
          },
          "number_of_cores": '4',
          "memory": '256 KB'
        },
        "os_details": { "product_version": '10.13.6',
                        "build_version": '17G65' },
        "name": 'Test',
        "date": 'YYYY-MM-DD HH:MM:SS'
      }
      expect(sample_data1.get_occurrence_of_key('build_version')).to eq 4
      expect(sample_data1.get_occurrence_of_value('256 KB')).to eq 2
      another_sample_data = [{}, sample_data1, { 'a': 'b' }]
      expect(another_sample_data.get_occurrence_of_key('build_version')).to eq 4
      expect(another_sample_data.get_occurrence_of_value('256 KB')).to eq 2
    end

    it '3. Verification for second sample data' do
      sample_data2 = {
        "hardware_details": {
          "model_name": 'MacBook Pro',
          "processor_details": [
            {
              "processor_name": '4',
              "processor_speed": '2.7 GHz',
              "core_details": {
                "total_numberof_cores": '4',
                "l2_cache(per_core)": '256 KB'
              }
            }
          ],
          "total_number_of_cores": '4',
          "memory": '16 GB'
        }
      }
      expect(sample_data2.get_occurrence_of_key('core_details')).to eq 1
      expect(sample_data2.get_occurrence_of_value('4')).to eq 3
    end

    it '4. Verification for third sample data' do
      sample_data3 = {
        "hardware_details": {
          "model_name": 'MacBook Pro',
          "processor_details": [
            { "total_number_of_cores": '4',
              "processor_speed": '2.7 GHz' },
            { "total_number_of_cores": '4',
              "l2_cache(per_core)": '256 KB' }
          ],
          "total_number_of_cores": '4',
          "memory": '16 GB'
        }
      }
      expect(sample_data3.get_occurrence_of_key(
          'total_number_of_cores'
      )).to eq 3
      expect(sample_data3.get_occurrence_of_value('4')).to eq 3
    end

    it '5. Verification for fourth sample data' do
      sample_data4 = {
        "values": [
          {
            "checks": [
              {
                "monitoring_zones":
                %w[mzdfw mzfra mzhkg mziad mzlon mzord mzsyd]
              }
            ]
          }
        ]
      }

      expect(sample_data4.get_occurrence_of_value('mzhkg')).to eq 1
      sample_data4[:values][0][:checks][0][:monitoring_zones].push('mzhkg')
      expect(sample_data4.get_occurrence_of_value('mzhkg')).to eq 2
    end
  end
end
