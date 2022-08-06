#!/bin/bash
rsync -aP ~/Music/ /media/dalius/Daliaus/Music
rsync -aP /media/dalius/Daliaus/Music/ ~/Music

rsync -aP ~/Pictures/ /media/dalius/Daliaus/Pictures
rsync -aP /media/dalius/Daliaus/Pictures/ ~/Pictures

rsync -aP ~/Videos/ /media/dalius/Daliaus/Videos
rsync -aP /media/dalius/Daliaus/Videos/ ~/Videos

rsync -aP ~/Documents/ /media/dalius/Daliaus/Documents
rsync -aP /media/dalius/Daliaus/Documents/ ~/Documents
