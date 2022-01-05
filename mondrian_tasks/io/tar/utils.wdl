version 1.0

task tarFiles{
    input{
        Array[File] inputs
        String? singularity_image
        String? docker_image

        String filename_prefix = "output"
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
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
