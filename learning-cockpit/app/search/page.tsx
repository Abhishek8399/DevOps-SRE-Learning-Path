import type { Metadata } from "next";
import { searchDocuments } from "./search-catalog";
import SearchClient from "./search-client";

export const metadata: Metadata = {
  title: "Search the field manual",
  description:
    "Search the locally available systems-reliability lessons by incident signal, command, term, or lesson identifier.",
};

export default function SearchPage() {
  return <SearchClient documents={searchDocuments} />;
}
