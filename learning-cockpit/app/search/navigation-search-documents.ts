import type { SearchDocument } from "./search-index";

export const navigationSearchDocuments: readonly SearchDocument[] = [
  {
    id: "career-map",
    number: "00",
    volumeNumber: "00",
    volumeTitle: "Field manual navigation",
    title: "Career map",
    subtitle: "Role-driven foundations, specialist tracks, and interview practice",
    href: "/career",
    fields: [
      { category: "Title", values: ["career map", "role map", "specialist tracks"], weight: 12 },
      { category: "Term", values: ["platform engineer", "SRE", "cloud engineer", "career"], weight: 8 },
    ],
  },
  {
    id: "interview-practice",
    number: "01",
    volumeNumber: "00",
    volumeTitle: "Field manual navigation",
    title: "Interview practice",
    subtitle: "Incident, recall, teach-back, and senior scenario defense",
    href: "/practice/interview",
    fields: [
      { category: "Title", values: ["interview practice", "interview", "scenario defense"], weight: 12 },
      { category: "Term", values: ["Linux", "networking", "SRE", "platform", "incident"], weight: 8 },
    ],
  },
];
