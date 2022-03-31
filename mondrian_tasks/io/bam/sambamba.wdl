version 1.0

task MergeBams{
    input{
        Array[File] input_bams
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 48
        Int? num_threads = 8
    }
    command{
        sambamba merge -t ~{num_threads} output.bam ~{sep=" "input_bams}
        samtools index output.bam
    }
    output{
        File merged_bam = "output.bam"
        File merged_bai = "output.bam.bai"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: "~{num_threads}"
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
