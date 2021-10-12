#!/usr/bin/env python

import time
from datetime import datetime

age = datetime.now() - datetime.strptime('10OCT1992', '%d%b%Y')
print(age.total_seconds()/31536000)
