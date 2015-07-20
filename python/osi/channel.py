class Channel(object):
    """Which channel we are communicating on

    """

    def __init__(self, id):
        self.id = id
        self.hz = 910E6

        # print 'setting id to', self.id

    def changehz(self, hz):
        if hz > 928E6:
            raise RuntimeError('Frequency too high.')
        if hz < 902E6:
            raise RuntimeError('Frequency too low.')
        self.hz = hz




if __name__ == '__main__':
    c = Channel('123')
    c.changehz(912.4E6)
    print c.hz