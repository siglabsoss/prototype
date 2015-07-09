import zmq


class SigSink(object):


    def __init__(self, port):
        self.port = port

        self.zmq_context = zmq.Context()
        self.zsock = self.zmq_context.socket(zmq.PUB)

        self.zsock.bind('tcp://*:%d' % self.port)


    def send(self, data):
        self.zsock.send(data)

    def send_pyobj(self, data):
        self.zsock.send_pyobj(data)