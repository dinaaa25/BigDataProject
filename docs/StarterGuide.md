### Starter Guide 

This guide is intended to show every coder building a similar project, how to get started. 

1. View and understand the song datatsets:

 &rarr; Go to your command line and enter:

>```  
> hdfs dfs -text /data/doina/OSCD-MillionSongDataset/ | head -1
>``` 

>```
> pyspark
>```

>```
> df = spark.read.csv("/data/doina/OSCD-MillionSongDataset/output_A.csv")
> df.show()
>```

**_NOTE:_**  Making sure the first line of the csv file is used for the header, so we can see the column names. 
>````
> df = spark.read.option('header', True).csv("/data/doina/OSCD-MillionSongDataset/output_A.csv")
>``````

>```
> df.select("artist_name").show()
>```

2. Go back to your command line and download the genre zip file to the NFS from the website tagestraum see for link in the readme.

>```
> wget [path]
>```

3. Unzip the downloaded zipfile
>```
> unzip [filename]
>```

4. You can view the file after unzipping it via using the cat command to print the file to the output console.
>```
> cat [filename]
>```

Or by viewing the content of the unzipped file in a file.

>```
> less [filename]
>```

5. Now make a folder on the HDFS, so that we can copy this unzipped file from the NFS to the HDFS
>```
> hdfs dfs -mkdir [foldername]
>```

Example:
>```
> hdfs dfs -mkdir project
>```


6. Now copy file from NFS to HDFS folder. 
Example:

>```
> hdfs dfs -cp file:///home/s2345846/msd_tagtraum_cd2.cls.zip     /user/s2345846/project
>```
&rarr; the file:// shows that it is from nfs

7. To check if the file was successfully copied to the project folder on the HDFS you can do:
>```
> hdfs dfs -ls project
>```

If you are using vscode and make use of the conda environment manager:

1. In the Terminal name the conda environment manager spark via:
>```
> conda create —name spark
>```

2. Leave the Base state because you do not want to install pyspark in Base but in the conda environment so all new changed which conda handles as an environment manager are updated by the conda environment manager.
>```
> conda activate spark
>```

3. Enter:
>```
> conda install pyspark
>```

4. Press (on mac) command p and select the following:

<img style='margin-right: auto; marign-left: auto;' src='Screen Shot 2023-12-21 at 16.28.43.png'/>

<img style='margin-right: auto; marign-left: auto;' src='Screen Shot 2023-12-21 at 16.28.23.png'/>














