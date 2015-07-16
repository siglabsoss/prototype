class Channel(object):
    """Which channel we are communicating on

    """

    def __init__(self, id):
        self.id = id
        self.hz = 910E6

    def change(self, hz):
        if hz > 928E6:
            raise RuntimeError('Frequency too high.')
        if hz < 902E6:
            raise RuntimeError('Frequency too low.')
        self.hz = hz




if __name__ == '__main__':
    c = Channel('123')
    c.change(912.4)
    print c.mhz