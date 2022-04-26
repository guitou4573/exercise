import logging
import os

SERVICE_URL = f'https://github.com/'
 
LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.INFO)
 
def healthcheck():
   
  
def handler(event, context):
   LOGGER.info('Event: %s', event)
 
   LOGGER.info('Checking endpoint: %s', SERVICE_URL)
   healthcheck()