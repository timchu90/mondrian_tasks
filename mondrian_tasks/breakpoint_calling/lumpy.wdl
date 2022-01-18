version 1.0


task extractSplitReads{
    input {
        File inputBam
        String outputBam
        String? singularity_image
        String? docker_image
    }
    command {
        samtools view -h ~{inputBam} | lumpy_extractSplitReads_BwaMem -i stdin | samtools view -Sb - > ~{outputBam}
    }
    output {
        File bamFile = outputBam
    }
    runtime{
        memory: "8 GB"
        cpu: 1
        walltime: "48:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task lumpyExpress{
    input{
        File normalSplitBam
        File tumourSplitBam
        File normalDiscBam
        File tumourDiscBam
        File normal_bam
        File tumour_bam
        String? singularity_image
        String? docker_image
        String filename_prefix
    }
    command{
        lumpyexpress -B ~{normal_bam},~{tumour_bam} -S ~{normalSplitBam},~{tumourSplitBam} -D ~{normalDiscBam},~{tumourDiscBam} -o ~{filename_prefix}_lumpy.vcf
    }
    output{
        File lumpy_vcf = '~{filename_prefix}_lumpy.vcf'
    }
    runtime{
        memory: "40 GB"
        cpu: 1
        walltime: "240:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
