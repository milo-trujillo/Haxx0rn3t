#!/usr/bin/env ruby

=begin
	This is a threadsafe centralized currency system. The currency (called 
	"assets") guarantees three things:
		* Currency can be transferred (or stolen)
		* Currency cannot be forged
		* Currency cannot be duplicated
	It accomplishes these goals by assigning a long and random serial number
	to each asset. Money can be transferred by giving someone else the serial
	number. Money cannot be forged because the made up serial numbers will not
	be in the central database. Money cannot be duplicated because when money
	is redeemed the serial number is invalidated, making any duplicate assets
	worthless.
=end

require 'thread'

module Currency
	AssetLength = 40
	$validAssets = Hash.new
	$expiredAssets = Hash.new
	$assetLock = Mutex.new

	def Currency.numAssets
		$assetLock.synchronize {
			return $validAssets.length 
		}
	end

	def Currency.numGeneratedAssets
		$assetLock.synchronize {
			return $validAssets.length + $expiredAssets.length
		}
	end

	# Issues a new asset not yet in circulation
	def Currency.genAsset
		while( true )
			asset = ""
			for x in (1 .. AssetLength)
				asset += (97 + rand(25)).chr
			end
			$assetLock.synchronize {
				if( $validAssets[asset] == nil && $expiredAssets[asset] == nil )
					$validAssets[asset] = 1
					return asset
				end
			}
		end
	end

	# Removes an asset from circulation, returns false if the asset never
	# existed, or true if it did and was removed successfully
	def Currency.expireAsset(asset)
		$assetLock.synchronize {
			success = $validAssets.delete(asset)
			if( !success )
				return false
			else
				$expiredAssets[asset] = 1
				return true
			end
		}
	end

	# Returns if an asset is currently valid
	def Currency.isValidAsset?(asset)
		if( asset.length != AssetLength )
			return false
		end
		$assetLock.synchronize {
			if( $validAssets[asset] != nil )
				return true
			else
				return false
			end
		}
	end

	# Saves current state of the currency to disk
	# returns success or failure
	def Currency.saveManifest(filename)
		begin
			f = File.open(filename, "w")
			$assetLock.synchronize {
				for v in $validAssets.keys
					f.puts("v:" + v)
				end
				for e in $expiredAssets.keys
					f.puts("e:" + e)
				end
			}
			f.close
			return true
		rescue
			f.close unless f.closed?
			return false
		end
	end

	# Load an old currency state from disk
	# returns success or failure
	def Currency.loadManifest(filename)
		if( !File.exists?(filename) )
			return false
		end

		valid = Array.new
		expired = Array.new

		begin
			File.open(filename, "r").readlines.each do |line|
				line = line.chomp
				if line.match(/^v:/)
					valid.push(line[2..-1])
				elsif line.match(/^e:/)
					expired.push(line[2..-1])
				else
					puts "Currency line (#{line}) invalid!"
					return false
				end
			end
		rescue
			f.close unless f.closed?
			return false
		end

		$assetLock.synchronize {
			for v in valid
				$validAssets[v] = 1
			end
			for e in expired
				$expiredAssets[e] = 1
			end
		}
		return true
	end

	# Wipes out all records of valid and invalid assets
	def Currency.reset
		$assetLock.synchronize {
			$validAssets.clear
			$expiredAssets.clear
		}
	end
end

def testCurrency
	foo = Currency.genAsset
	if( Currency.isValidAsset?(foo) )
		puts (foo + " is a valid asset")
	else
		puts (foo + " is not a valid asset")
	end

	success = Currency.expireAsset(foo)
	if( success )
		puts "Successfully retired asset"
	end
	if( Currency.isValidAsset?(foo) )
		puts (foo + " is a valid asset")
	else
		puts (foo + " is not a valid asset")
	end


	foo = "foo"
	if( Currency.isValidAsset?(foo) )
		puts (foo + " is a valid asset")
	else
		puts (foo + " is not a valid asset")
	end

	puts "Valid assets: #{Currency.numAssets}"
	puts "Total assets: #{Currency.numGeneratedAssets}"

	Currency.saveManifest("manifesttest.db")
	Currency.reset
	puts "Reset currency system"
	puts "Valid assets: #{Currency.numAssets}"
	puts "Total assets: #{Currency.numGeneratedAssets}"
	Currency.loadManifest("manifesttest.db")
	puts "Restored currency system from disk"
	puts "Valid assets: #{Currency.numAssets}"
	puts "Total assets: #{Currency.numGeneratedAssets}"
end
