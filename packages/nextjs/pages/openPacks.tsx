import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { MetaHeader } from "~~/components/MetaHeader";
import { RainbowKitCustomConnectButton } from "~~/components/scaffold-eth";
import { MyHoldings, MyCards } from "~~/components/simpleNFT";
import { useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

const MyNFTs: NextPage = () => {
  const { address: connectedAddress, isConnected, isConnecting } = useAccount();

  const { writeAsync: mintItem } = useScaffoldContractWrite({
    contractName: "MyPacks",
    functionName: "mint",
    args: [BigInt("1")],
  });

  const { writeAsync: openPack } = useScaffoldContractWrite({
    contractName: "MyPacks",
    functionName: "openPack"
  });

  const { data: tokenIdCounter } = useScaffoldContractRead({
    contractName: "MyPacks",
    functionName: "balanceOf",
    args: [connectedAddress, BigInt("1")],
  });

  const handleMintItem = async () => {
    // circle back to the zero item if we've reached the end of the array
    if (tokenIdCounter === undefined) return;

    try {
      await mintItem({
        args: [BigInt("1")],
      });
    } catch (error) {
      console.error(error);
    }
  };

  const handleOpenPack = async () => {
    try {
      await openPack({});
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <>
      <MetaHeader />
      <div className="flex items-center flex-col pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-4xl font-bold">Open Packs</span>
          </h1>
        </div>
      </div>
      <div className="flex justify-center">
        {!isConnected || isConnecting ? (
          <RainbowKitCustomConnectButton />
        ) : (
          <button className="btn btn-secondary" onClick={handleMintItem}>
            Mint NFT
          </button>
        )}
      </div>
      <MyHoldings />

      <div className="flex justify-center">
        {!isConnected || isConnecting ? (
          <RainbowKitCustomConnectButton />
        ) : (
          <button className="btn btn-secondary" onClick={handleOpenPack}>
            OPEN PACK
          </button>
        )}
      </div>
      <MyCards />
    </>
  );
};

export default MyNFTs;
