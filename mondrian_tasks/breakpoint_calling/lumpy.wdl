version 1.0


task ExtractSplitReads{
    input {
        File inputBam
        String outputBam
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 48
    }
    command {
        samtools view -h ~{inputBam} | lumpy_extractSplitReads_BwaMem -i stdin | samtools view -Sb - > ~{outputBam}
    }
    output {
        File bamFile = outputBam
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task LumpyExpress{
    input{
        File normalSplitBam
        File tumourSplitBam
        File normalDiscBam
        File tumourDiscBam
        File normal_bam
        File tumour_bam
        String filename_prefix
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 96
    }
    command{
        lumpyexpress -B ~{normal_bam},~{tumour_bam} -S ~{normalSplitBam},~{tumourSplitBam} -D ~{normalDiscBam},~{tumourDiscBam} -o ~{filename_prefix}_lumpy.vcf
    }
    output{
        File lumpy_vcf = '~{filename_prefix}_lumpy.vcf'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
