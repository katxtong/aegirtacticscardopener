import { useEffect, useState, useRef } from "react";
import { Spinner } from "../Spinner";
import { NFTCard } from "./NFTCard";
import { useAccount } from "wagmi";
import { useScaffoldContract, useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";
import { NFTMetaData, getNFTMetadataFromIPFS } from "~~/utils/simpleNFT";

export interface Collectible2 extends Partial<NFTMetaData> {
    id: number;
    uri: string;
    owner: string;
}

export const MyCards = () => {

    const { address: connectedAddress } = useAccount();
    const [myAllCollectibles, setMyAllCollectibles] = useState<Collectible2[]>([]);
    const [allCollectiblesLoading, setAllCollectiblesLoading] = useState(false);

    const { data: yourCollectibleContract } = useScaffoldContract({
        contractName: "MyPacks",
    });

    const { data: myPackBalance } = useScaffoldContractRead({
        contractName: "MyPacks",
        functionName: "balanceOf",
        args: [connectedAddress, BigInt(1)],
        watch: true,
    });

    const cardIdsWithDataRef = useRef<number[]>([]);

    const fetchNFTs = async () => {
        if (!yourCollectibleContract || !connectedAddress) return;

        try {
            const cardIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
            const promises = cardIds.map(async (cardId) => {
                try {
                    // Fetch data directly using contract's read function
                    const data = await yourCollectibleContract.read.getCardBalanceOf([connectedAddress, BigInt(cardId)]);

                    // Return an object with cardId and corresponding data
                    return { cardId, data };

                } catch (error) {
                    console.error(`Error fetching balance for card ${cardId}`, error);
                    return undefined;
                }
            });

            // Filter out undefined values and only keep entries where data is greater than 0
            cardIdsWithDataRef.current = (await Promise.all(promises))
                .reduce((acc: number[], result) => {
                    if (result !== undefined && result.data > 0) {
                        // Repeat cardId based on the value returned from the contract
                        for (let i = 0; i < result.data; i++) {
                            acc.push(result.cardId);
                        }
                    }
                    return acc;
                }, []);
        } catch (error) {
            notification.error("Error fetching NFT balances");
            console.error(error);
        } finally {
            setAllCollectiblesLoading(false);
        }
    };

    useEffect(() => {
        const updateMyCollectibles = async (): Promise<void> => {
            if (myPackBalance === undefined || yourCollectibleContract === undefined ||
                connectedAddress === undefined)
                return;

            fetchNFTs();
            setAllCollectiblesLoading(true);

            const collectibleUpdate: Collectible2[] = [];

            for (const cardId of cardIdsWithDataRef.current) {
                try {
                    // const numOwned = await yourCollectibleContract.read.getCardBalanceOf([
                    //     connectedAddress,
                    //     BigInt(cardId)
                    // ]);

                    // const tokenURI = await yourCollectibleContract.read.getCardUri([tokenId]);
                    const tokenURI = await yourCollectibleContract.read.getCardUri([BigInt(cardId)]);

                    const ipfsHash = tokenURI.replace("https://ipfs.io/ipfs/", "");

                    const nftMetadata: NFTMetaData = await getNFTMetadataFromIPFS(ipfsHash);

                    collectibleUpdate.push({
                        id: parseInt(cardId.toString()),
                        uri: tokenURI,
                        owner: connectedAddress,
                        ...nftMetadata,
                    });

                } catch (e) {
                    notification.error("Error fetching all collectibles");
                    setAllCollectiblesLoading(false);
                    console.log(e);
                }
            }
            //for (const cardId of cardIdsWithDataRef.current) {
            // for (const cardId of balanceResults) {
            //     try {
            //         const tokenURI = await yourCollectibleContract.read.getCardUri([BigInt(cardId)]);
            //         const ipfsHash = tokenURI.replace("https://ipfs.io/ipfs/", "");
            //         const nftMetadata: NFTMetaData = await getNFTMetadataFromIPFS(ipfsHash);

            //         collectibleUpdate.push({
            //             id: parseInt(cardId.toString()),
            //             uri: tokenURI,
            //             owner: connectedAddress,
            //             ...nftMetadata,
            //         });

            //     } catch (e) {
            //         notification.error("Error fetching all collectibles");
            //         setAllCollectiblesLoading(false);
            //         console.log(e);
            //     }
            // }
            collectibleUpdate.sort((a, b) => a.id - b.id);
            setMyAllCollectibles(collectibleUpdate);
            setAllCollectiblesLoading(false);
        };

        updateMyCollectibles();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [connectedAddress, myPackBalance]);

    if (allCollectiblesLoading)
        return (
            <div className="flex justify-center items-center mt-10">
                <Spinner width="75" height="75" />
            </div>
        );

    return (
        <>
            <br />
            {myAllCollectibles.length === 0 ? (
                <div className="flex justify-center items-center mt-2">
                    <div className="text-2xl text-primary-content">No Cards found</div>
                </div>
            ) : (
                <div className="flex flex-wrap gap-4 justify-center">
                    {myAllCollectibles.map(item => (
                        <NFTCard nft={item} key={item.id} />
                    ))}
                </div>
            )}

            <br /> {/* Add a line break here */}

            <div className="flex justify-center items-center mt-5">
                <p>Card IDs Minted From Packs: {cardIdsWithDataRef.current.join(', ')}</p>
            </div>

            <div className="flex justify-center items-center mt-5">
                <p>Check your Collection on {' '}
                    {connectedAddress && (
                        <a
                            href={`https://testnets.opensea.io/accounts/${connectedAddress}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            style={{ color: 'blue' }}
                        >
                            {`Opensea`}
                        </a>
                    )}
                </p>
            </div>
        </>
    );
};