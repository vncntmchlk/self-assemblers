import logging
import threading
import time

logging.basicConfig(level=logging.DEBUG,
                    format='(%(threadName)-10s) %(message)s',
                    )

def wait_for_event_timeout(e):
    while not e.isSet():
        logging.debug('start camera capture ..')
        event_is_set = e.wait()
        if event_is_set:
            logging.debug('quit camera capture')


e = threading.Event()
t = threading.Thread(target=wait_for_event_timeout, args=(e,))
t.start()

logging.debug('Waiting before calling Event.set()')
time.sleep(3)
e.set()
logging.debug('Event is set')