version 1.0

task CopyFiles {
    input {
        Array[File] infile
        String out_dir
        String? singularity_image
        String? docker_image
        Int? memory_gb = 8
        Int? walltime_hours = 8
    }
    command {
        mkdir -p ~{out_dir}
        cp ~{sep=" "infile}  ~{out_dir}
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
    }
}
