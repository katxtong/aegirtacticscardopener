import Link from "next/link";
import type { NextPage } from "next";
import { BugAntIcon, CursorArrowRaysIcon } from "@heroicons/react/24/outline";
import { MetaHeader } from "~~/components/MetaHeader";

const Home: NextPage = () => {

  return (
    <>
      <MetaHeader />
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="flex flex-wrap gap-4 justify-center">
          <img
            src="https://ipfs.algonft.tools/ipfs/QmWajSatXwPAfyqnmQ2G9uQQiTn64PPScWsFWZrRhvmjz6#i"
            alt="Your NFT Image"
            className="max-w-full h-auto w-32"
          />
        </div>
        <div className="px-5 text-center">
          <h1 className="text-4xl font-bold mb-4">Aegir Tactics</h1>
          <p className="text-lg">Star Sight Labs</p>
          <Link href="https://app.nf.domains/name/aegirtactics.algo">
            aegirtactics.algo
          </Link>

          <p className="text-lg mt-4">
            Aegir Tactics is a next generation digital card game designed to bring fairness and balance back to competitive play.
          </p>
          <p className="text-lg mt-4">
            Mythic Legends are a premium version of legends. They feature prominent characters from the game universe and will be released in limited supply. Each Legend comes with a deck of cards on their class which will be playable upon release. In addition to being a limited edition cosmetic, Mythic Legends will also have access to Quests and Aegir Dungeons.
          </p>

        </div>
      </div>

      <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
        <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
          <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
            <CursorArrowRaysIcon className="h-8 w-8 fill-secondary" />
            <p>
              Mint and open new packs with the {" "}
              <Link href="/openPacks" passHref className="link">
                Open Packs
              </Link>{" "}
              tab.
            </p>
          </div>
          <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
            <BugAntIcon className="h-7 w-7 fill-secondary" />
            <p>
              Tinker with the ERC1155 contract using the {" "}
              <Link href="/debug" passHref className="link">
                Debug Contract
              </Link>{" "}
              tab.
            </p>
          </div>

        </div>
      </div>
    </>
  );
};

export default Home;
