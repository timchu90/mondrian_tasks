version 1.0

task tarFiles{
    input{
        Array[File] inputs
        String? singularity_dir
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
        docker: 'quay.io/mondrianscwgs/alignment:v0.0.6'
        singularity: '~{singularity_dir}/alignment_v0.0.6.sif'
    }
}
