version 1.0

task TarFiles{
    input{
        Array[File] inputs
        String filename_prefix = "output"
        String? singularity_image
        String? docker_image
        Int? memory_gb = 8
        Int? walltime_hours = 8
    }
    command{
        mkdir ~{filename_prefix}
        cp ~{sep=" "inputs} ~{filename_prefix}
        tar -cvf ~{filename_prefix}.tar ~{filename_prefix}
        gzip ~{filename_prefix}.tar
    }

    output{
        File tar_output = '~{filename_prefix}.tar.gz'
    }
    runtime{
        memory: '~{memory_gb} GB'
        cpu: 1
        walltime: '~{walltime_hours}:00'
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
