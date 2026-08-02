declare module "*.md?raw" {
  const content: string;
  export default content;
}

declare module "virtual:book-lesson/*" {
  const content: string;
  export default content;
}
