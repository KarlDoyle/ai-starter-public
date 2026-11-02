// Runs before every test file.
//
// When the suite runs from a git hook (`pre-push` in particular) git exports GIT_DIR,
// GIT_INDEX_FILE and friends, pointing at the repository being pushed. Tests that build
// a throwaway repository in a temp directory could otherwise read and write the parent checkout
// instead. Strip them, so a hook-run suite behaves exactly like a terminal-run one.
//
// Ships with the standard because the failure is silent and expensive: it cost a corrupted
// git configuration in the parent checkout. Code that runs git itself should
// strip the same variables at the call site.
for (const key of [
  "GIT_DIR",
  "GIT_WORK_TREE",
  "GIT_INDEX_FILE",
  "GIT_COMMON_DIR",
  "GIT_OBJECT_DIRECTORY",
  "GIT_ALTERNATE_OBJECT_DIRECTORIES",
  "GIT_NAMESPACE",
  "GIT_PREFIX",
]) {
  delete process.env[key];
}
