#!/usr/bin/env ruby

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
end

foo = Currency.genAsset
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
