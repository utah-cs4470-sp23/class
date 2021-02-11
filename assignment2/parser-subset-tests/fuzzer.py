
#pip install fuzzingbook
import fuzzingbook.Grammars as fb

from fuzzingbook.MutationFuzzer import MutationFuzzer

import argparse
import random
from datetime import datetime
from pathlib import Path
import string

JPL_EBNF_GRAMMAR = {
    "<start>": ["<cmd>"],
    "<cmd>": ["read image <string> to <argument>", "write image <expr> to <string>", "print <string>", "show <expr>", "time <cmd>", "<stmt>"],
    "<stmt>": ["let <lvalue> = <expr>", "assert <expr>, <string>", "return <expr>"],
    "<expr>": ["<integer>", "<float>", "<variable>", "<fn_call>"],

    "<lvalue>": ["<argument>"],
    "<argument>": ["<variable>"],

    "<float>": ["<integer>+.<integer>*", ".<integer>+"],
    "<integer>": ["<digit>+"],
    "<variable>": ["<letter>(<digit><letter><var_spec_char>)*"],
    "<fn_call>": ["<variable>(<expr_seq>)"],
    "<string>": ['"<str_char>*"'],

    "<expr_seq>": ["<expr_seq_suffix>?"],
    "<expr_seq_suffix>": ["<expr>(<comma><expr_seq_suffix>)*"],
#    "<var_suffix>": ["<digit>", "<letter>", "_", "."],
    "<var_spec_char>": ["_", "."],
    "<digit>": fb.srange(string.digits),
    "<letter>": fb.srange(string.ascii_letters),
    "<comma>": [", "],
    "<str_char>": [' ', '!', '#', '$', '%', '&', "'", '(', ')', '*', '+', ',', '-', '.', '/', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\\', ']', '^', '_', '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~']
}

JPL_GRAMMAR = fb.convert_ebnf_grammar(JPL_EBNF_GRAMMAR)

def generate(test_num, min_test_len, max_test_len, out_dir, max_non_terminals):
    assert fb.is_valid_grammar(JPL_GRAMMAR)

    seed = datetime.now()
    print ("Seed is ", seed)
    random.seed(seed)

    Path(out_dir).mkdir(parents=True, exist_ok=True)

    for test_id in range(test_num):
        print("Test #", test_id)
        test_len = int(random.uniform(min_test_len, max_test_len))
        content = ([fb.simple_grammar_fuzzer(JPL_GRAMMAR, max_nonterminals=max_non_terminals) for i in range(test_len)])
        #m = MutationFuzzer(content)
        #content = [m.fuzz() for i in range(20)]
        with open(Path(out_dir, str(test_id) + ".jpl"), "w") as out_file:
            out_file.write('\n'.join(content + [""]))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate tests for JPL',\
                                     epilog="You can run it with python3.8 fuzzer.py 2 1 20 --max-non-terminals 200 --out-dir out")
    parser.add_argument('test_num', type=int, default=1,
                        help='Number of tests to generate')
    parser.add_argument('min_test_len', type=int, default=1,
                        help='minimal test length')
    parser.add_argument('max_test_len', type=int, default=10,
                        help='maximal test length')
    parser.add_argument('--out-dir', type=Path, default="out",
                        help='Output directory')
    parser.add_argument('--max-non-terminals', type=int, default=5,
                        help='Maximal number of non-terminals in production chain')
    args = parser.parse_args()
    generate(args.test_num, args.min_test_len, args.max_test_len, args.out_dir, args.max_non_terminals)
