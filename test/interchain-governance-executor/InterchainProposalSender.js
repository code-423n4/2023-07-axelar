const hre = require('hardhat');
const { expect } = require('chai');
const { deployAll } = require('../../scripts/deploy');

const ethers = hre.ethers;

describe('Interchain Governance Sender', function () {
    let sender;
    let signer;
    let signerAddress;
    let gasService;
    let gateway;

    before(async () => {
        [signer] = await ethers.getSigners();
        [, gateway, gasService] = await deployAll(signer, 'Test');
        signerAddress = await signer.getAddress();
        const senderFactory = await ethers.getContractFactory('InterchainProposalSender');
        sender = await senderFactory.deploy(gateway.address, gasService.address);
    });

    describe('sendProposal', function () {
        it('should be able to call gateway and gasService contracts successfully', async function () {
            const target = await ethers.getSigners().then((signers) => signers[1].getAddress());

            const calls = [
                {
                    target,
                    value: 0,
                    callData: ethers.utils.randomBytes(32),
                },
                {
                    target,
                    value: 1,
                    callData: ethers.utils.randomBytes(32),
                },
                {
                    target,
                    value: 2,
                    callData: ethers.utils.randomBytes(32),
                },
            ];

            const broadcast = () => sender.sendProposal('avalanche', ethers.constants.AddressZero, calls, { value: 1 });

            const payload = ethers.utils.defaultAbiCoder.encode(
                ['address', 'tuple(address target, uint256 value, bytes callData)[]'],
                [signerAddress, calls],
            );

            const payloadHash = ethers.utils.keccak256(payload);

            await expect(broadcast())
                .to.emit(gasService, 'NativeGasPaidForContractCall(address,string,string,bytes32,uint256,address)')
                .withArgs(sender.address, 'avalanche', ethers.constants.AddressZero, payloadHash, 1, await signer.getAddress());

            await expect(broadcast())
                .to.emit(gateway, 'ContractCall(address,string,string,bytes32,bytes)')
                .withArgs(sender.address, 'avalanche', ethers.constants.AddressZero, payloadHash, payload);
        });
    });

    describe('sendProposals', function () {
        it('should be able to call gateway and gasService contracts successfully', async function () {
            const target = await ethers.getSigners().then((signers) => signers[1].getAddress());

            const calls = [
                {
                    target,
                    value: 0,
                    callData: ethers.utils.randomBytes(32),
                },
                {
                    target,
                    value: 1,
                    callData: ethers.utils.randomBytes(32),
                },
                {
                    target,
                    value: 2,
                    callData: ethers.utils.randomBytes(32),
                },
            ];

            const destChains = ['avalanche', 'binance'];

            const xCalls = [
                {
                    destinationChain: destChains[0],
                    destinationContract: ethers.constants.AddressZero,
                    gas: 1,
                    calls,
                },
                {
                    destinationChain: destChains[1],
                    destinationContract: ethers.constants.AddressZero,
                    gas: 1,
                    calls,
                },
            ];

            const broadcast = () => sender.sendProposals(xCalls, { value: 2 });

            const payload = ethers.utils.defaultAbiCoder.encode(
                ['address', 'tuple(address target, uint256 value, bytes callData)[]'],
                [signerAddress, calls],
            );

            const payloadHash = ethers.utils.keccak256(payload);

            for (const destChain of destChains) {
                await expect(broadcast())
                    .to.emit(gasService, 'NativeGasPaidForContractCall(address,string,string,bytes32,uint256,address)')
                    .withArgs(sender.address, destChain, ethers.constants.AddressZero, payloadHash, 1, signerAddress);

                await expect(broadcast())
                    .to.emit(gateway, 'ContractCall(address,string,string,bytes32,bytes)')
                    .withArgs(sender.address, destChain, ethers.constants.AddressZero, payloadHash, payload);
            }

            const senderContractBalance = await hre.ethers.provider.getBalance(sender.address);
            expect(senderContractBalance).to.equal(0);
        });
    });
});
