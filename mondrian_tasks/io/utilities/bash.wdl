version 1.0

task CopyFiles {
    input {
        Array[File] infile
        String out_dir
    }
    command {
        mkdir -p ~{out_dir}
        cp ~{sep=" "infile}  ~{out_dir}
    }
    runtime{
        memory: "8G"
        cpu: 1
        walltime: "6:00"
    }
}
