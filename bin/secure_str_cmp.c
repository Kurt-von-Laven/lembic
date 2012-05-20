/*
 * Securely compares a pair of strings. Returns 0 if they are identical and
 * non-zero otherwise. When compiled without optimizations, performs the same
 * machine-level instructions the same number of times regardless of input.
 * Assumes all given strings are of a fixed positive length. The function's
 * intended use is verification of hash values associated with user login
 * credentials in a fashion immune to timing attacks. Expects exactly 2
 * arguments, the strings to compare. Returns 0 if no arguments are passed.
 * Doesn't provide any feedback on bad input, because it's optimized for
 * heavy-duty use by other programs.
 */
int main(int argc, char * const argv[]) {
  int result = 0; // Turn off all the bits in result. 
  
  const char *str_one = argv[1];
  const char *str_two = argv[2];
  
  /*
   * Until reaching the terminal null-byte at the end of the strings:
   * 
   *   (0) Turn on any bits in result that differ in the current character of
   *       str_one and str_two.
   *   (1) Advance to the next character in both str_one and str_two.
   */
  for (char curr_one = *str_one; 1; ++str_two) {
    result |= curr_one ^ *str_two;
    curr_one = *(++str_one);
    if (!curr_one) break;
  }
  
  /*
   * Iff any bits of any characters in any pair of strings differed, result will
   * be non-zero.
   */
  return result;
}
