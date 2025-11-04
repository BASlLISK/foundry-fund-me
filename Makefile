-include .env

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEP_URL) --private-key $(MM_Key) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
