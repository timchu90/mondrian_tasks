version 1.0

task SamToBam{
    input{
        File inputBam
        String outputSam
        String? singularity_image
        String? docker_image

    }
    command{
        samtools view -bSh ${inputBam} > ${outputSam}
    }

    output{
        File samfile = outputSam
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task indexBam{
    input{
        File inputBam
        String outputBai
        String? singularity_image
        String? docker_image

    }
    command{
    samtools index ${inputBam} ${outputBai}
    }

    output{
        File indexfile = outputBai
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task Flagstat{
    input{
        File input_bam
        String? singularity_image
        String? docker_image

        String filename_prefix = "output"

    }

    command{
        samtools flagstat ~{input_bam} > ~{filename_prefix}_flagstat.txt
    }
    output{
        File flagstat_txt = '~{filename_prefix}_flagstat.txt'
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task mergeBams{
    input{
        Array[File]+ inputBams
        String outputFile
        String? singularity_image
        String? docker_image

    }
    command{
        samtools merge ${outputFile} ${sep=' ' inputBams}
    }
    output{
        File mergedBam = outputFile
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task viewBam{
    input{
        File inputBam
        String outputBam
        Int? bam_flag
        String samtools_flags
        String? singularity_image
        String? docker_image

    }
    command{
        samtools view ~{samtools_flags}  ~{"-F " + bam_flag} ${inputBam} > ${outputBam}
    }
    output{
        File bamFile = outputBam
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task sortBam{
    input {
        File inputBam
        String? singularity_image
        String? docker_image

    }
    command {
        samtools sort ${inputBam} -o sorted.bam
    }
    output {
        File sortedBam = 'sorted.bam'
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
