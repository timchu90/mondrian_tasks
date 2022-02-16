version 1.0


task RunFastqc{
    input{
        File fastq
        String? singularity_image
        String? docker_image

    }
    command<<<
        fastqc --outdir=`pwd` ~{fastq}
        mv *_fastqc.zip output_fastqc.zip
        mv *_fastqc.html output_fastqc.html

    >>>
    output{
        File fastqc_zip = "output_fastqc.zip"
        File fastqc_html = "output_fastqc.html"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}