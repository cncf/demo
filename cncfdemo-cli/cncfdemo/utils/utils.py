#!/usr/bin/env python

import os
import datetime

import requests
import imghdr


def getimg(url):
  r = requests.get(url)
  return r.content if r.ok else ''


def saveimg(img, path, ext, name='image'):
  with open(path+'/'+name+'.'+ext, 'wb') as f:
    f.write(img)


def grabimg(url, path='.'):
  img = getimg(URL)
  imgtype = imghdr.what(None, img) 
  return False if not imgtype else saveimg(img, path, imgtype)


def rfc3339(datetime_obj=datetime.datetime.now()):
  return datetime_obj.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%f')[:-4] + 'Z'


def makedir3339(path='.'):
  dir =  '/'.join((path, rfc3339()))
  os.makedirs('/'.join((path, rfc3339())))
  return dir


if __name__ == "__main__":

  # Just a check, will remove this

  URL = 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Caspar_David_Friedrich_-_Wanderer_above_the_sea_of_fog.jpg/600px-Caspar_David_Friedrich_-_Wanderer_above_the_sea_of_fog.jpg'
  
  grabimg(URL, path=makedir3339())
