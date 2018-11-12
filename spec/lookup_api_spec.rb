require_relative '../lib/nested_lookup'

RSpec.describe LookUpApi do
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
    @test_hash3 = {
      "hardware_details": {
        "model_name": 'MacBook Pro',
        "processor_details": [
          {
            "processor_name": 'Intel Core i7',
            "processor_speed": '2.7 GHz'
          },
          {
            "total_number_of_cores": '4',
            "l2_cache(per_core)": '256 KB'
          }
        ],
        "total_number_of_cores": '4',
        "memory": '16 GB'
      }
    }
    @test_hash4 = {
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
  end

  context '#Test1: Feature Get' do
    it '1. Verify Get for Unique keys' do
      result = { "d": 200 }
      expect(@test_hash1.nested_get('c')).to eq result
    end

    it '2. Verify return value is Hash' do
      expect(@test_hash1.nested_get('c')).to be_instance_of Hash
    end

    it '3. Verify Get for duplicate Keys' do
      expect(@test_hash1.nested_get('d')).to eq 200
    end

    it '4. Verify ErrorClass when no argument is passed' do
      expect { @test_hash1.nested_get }.to raise_error(ArgumentError)
    end

    it '5. Verify result for Array of Hashes' do
      expect([{}, @test_hash1, []].nested_get('d')).to eq 200
    end

    it '6. Verify result for wrapped Hashes in Array' do
      expect([{}, { 'e' => @test_hash1 }].nested_get('d')).to eq 200
    end
  end

  context '#Test2: Feature Delete' do
    context 'I. Verification for first sample data' do
      result = {
        "os_details": {
          "product_version": '10.13.6'
        },
        "name": 'Test',
        "date": 'YYYY-MM-DD HH:MM:SS'
      }

      it '1. Verification for normal method' do
        expect(@test_hash2.nested_delete('build_version')).to eq result
        expect(@test_hash2).to eq @test_hash2
      end

      it '2. Verification for bang method' do
        @test_hash2.nested_delete!('build_version')
        expect(@test_hash2).to eq result
      end

      it '3. Check for the Exception class' do
        expect { @test_hash2.nested_delete }.to raise_error(ArgumentError)
        expect { @test_hash2.nested_delete! }.to raise_error(ArgumentError)
      end
    end

    context 'II. Verification for second sample data' do
      result1 = {
        "hardware_details": {
          "model_name": 'MacBook Pro',
          "total_number_of_cores": '4',
          "memory": '16 GB'
        }
      }
      result2 = {
        "hardware_details": {
          "model_name": 'MacBook Pro',
          "processor_details": [
            {
              "processor_name": 'Intel Core i7',
              "processor_speed": '2.7 GHz'
            },
            {
              "l2_cache(per_core)": '256 KB'
            }
          ],
          "memory": '16 GB'
        }
      }

      it '1. Verification for normal method' do
        expect(@test_hash3.nested_delete('processor_details')).to eq result1
        expect(@test_hash3).to eq @test_hash3
      end

      it '2. Verification for bang method' do
        @test_hash3.nested_delete!('total_number_of_cores')
        expect(@test_hash3).to eq result2
      end
    end

    context 'III. Verification for third sample data' do
      result1 = {"values": [{"checks": [{}]}]}
      result2 = {"values": [{}]}

      it '1. Verification for normal method' do
        expect(@test_hash4.nested_delete('monitoring_zones')).to eq result1
        expect(@test_hash4).to eq @test_hash4
      end

      it '2. Verification for bang method' do
        @test_hash4.nested_delete!('checks')
        expect(@test_hash4).to eq result2
      end
    end
  end

  before do
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
    @test_hash3 = {
      "hardware_details": {
        "model_name": 'MacBook Pro',
        "processor_details": [
          {
            "processor_name": 'Intel Core i7',
            "processor_speed": '2.7 GHz'
          },
          {
            "total_number_of_cores": '4',
            "l2_cache(per_core)": '256 KB'
          }
        ],
        "total_number_of_cores": '4',
        "memory": '16 GB'
      }
    }
    @test_hash4 = {
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
  end
  context '#Test3: Feature Update' do
    context 'I. Verification for first sample data' do
      result = {
        "build_version": 'Test',
        "os_details": {
          "product_version": '10.13.6',
          "build_version": 'Test'
        },
        "name": 'Test',
        "date": 'YYYY-MM-DD HH:MM:SS'
      }

      it '1. Verification for normal method' do
        expect(@test_hash2.nested_update(key: 'build_version', value: 'Test')).to eq result
        expect(@test_hash2).to eq @test_hash2
      end

      it '2. Verification for bang method' do
        @test_hash2.nested_update!(key: 'build_version', value: 'Test')
        expect(@test_hash2).to eq result
      end
    end

    context 'II. Verification for second sample data' do
      result = {
        "hardware_details": {
          "model_name": 'MacBook Pro',
          "processor_details": 'Temp',
          "total_number_of_cores": '4',
          "memory": '16 GB'
        }
      }

      it '1. Verification for normal method' do
        expect(@test_hash3.nested_update(key: 'processor_details', value: 'Temp')).to eq result
        expect(@test_hash3).to eq @test_hash3
      end

      it '2. Verification for bang method' do
        @test_hash3.nested_update!(key: 'processor_details', value: 'Temp')
        expect(@test_hash3).to eq result
      end
    end

    context 'III. Verification for third sample data' do
      result = {"values": [{"checks": 'checks'}]}

      it '1. Verification for normal method' do
        expect(@test_hash4.nested_update(key: 'checks', value: 'checks')).to eq result
        expect(@test_hash4).to eq @test_hash4
      end

      it '2. Verification for bang method' do
        @test_hash4.nested_update!(key: 'checks', value: 'checks')
        expect(@test_hash4).to eq result
      end
    end
  end
end
