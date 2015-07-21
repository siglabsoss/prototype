import unittest
from enum import Enum
from switch import *


class FSM(Enum):
    one = 1
    two = 2
    potato = 3




class BasicConnection(unittest.TestCase):
    def runTest(self):

        # boil em
        state = 2

        for case in switch(state):
            if case(1):
                assert False
                break
            if case(2):
                assert True
                break
            if case(3):
                assert False
                break
            if case():
                assert False

        # mash em
        state = FSM.one

        for case in switch(state):
            if case(FSM.one):
                assert True
                break
            if case(FSM.two):
                assert False
                break
            if case(FSM.potato):
                assert False
                break
            if case():
                assert False

        # cook 'em in a stew
        state = 14

        for case in switch(state):
            if case(FSM.one):
                assert False
                break
            if case(FSM.two):
                assert False
                break
            if case(FSM.potato):
                assert False
                break
            if case():
                assert True


if __name__ == "__main__":
    unittest.main()