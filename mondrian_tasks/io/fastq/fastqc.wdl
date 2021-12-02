version 1.0


task RunFastqc{
    input{
        File fastq
        String? singularity_dir
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
        docker: 'us.gcr.io/nygc-dlp-s-c0c0/alignment:v0.0.6'
        singularity: '~{singularity_dir}/alignment_v0.0.6.sif'
    }
}