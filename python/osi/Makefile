siglabs_pb2.py: siglabs.proto
	protoc -I=. --python_out=. siglabs.proto

clean:
	rm siglabs_pb2.py

test:
	# all tests are in the text_xxx.py format.
	# this just passes them to python one at a time
	ls test_*py | xargs -n 1 python