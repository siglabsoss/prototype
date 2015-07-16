import zmq


class SigSource(object):


    def __init__(self):
        self.zmq_context = zmq.Context()

        self.zsock = self.zmq_context.socket(zmq.SUB)
        self.zsock.setsockopt(zmq.SUBSCRIBE, '') # empty string here subscribes to all channels

        self.poller = zmq.Poller()
        self.poller.register(self.zsock, zmq.POLLIN)

    # returns if there is any data waiting
    def waiting(self):
        socks = dict(self.poller.poll(0))
        if self.zsock in socks and socks[self.zsock] == zmq.POLLIN:
            return True
        return False
            # obj = octave_socket.recv()
            # # print obj
            # # for b in obj:
            # #     rx_fifo.append(ord(b))
            # #     print ord(b)
            # # print ''
            # # print ''
            # switch_zmq_message(obj)
            # obj = zmq_subscriber.recv_pyobj()
            # print 'zmq got', obj
            # obj['zmq'] = True # just in-case we need to distinguish this later
            # q.append(obj)

    def get(self):
        socks = dict(self.poller.poll(0))
        if self.zsock in socks and socks[self.zsock] == zmq.POLLIN:
            return self.zsock.recv()
        return False

    def get_pyobj(self):
        socks = dict(self.poller.poll(0))
        if self.zsock in socks and socks[self.zsock] == zmq.POLLIN:
            return self.zsock.recv_pyobj()
        return False

    def connect(self, sink):
        self.zsock.connect('tcp://127.0.0.1:%d' % sink.port)
