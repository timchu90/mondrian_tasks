version 1.0


task VariantBam{
    input{
        File input_bam
        File input_bai
        String interval
        String? singularity_image
        String? docker_image
        Int max_coverage=10000
        Int? num_threads = 1
        Int? memory_gb = 18
        Int? walltime_hours = 48
    }
    command{
        if [[ ~{num_threads} -eq 1 ]]
        then
            variant ~{input_bam} -m ~{max_coverage} -k ~{interval} -v -b -o output.bam
        else:
            intervals=`variant_utils split_interval --interval ~{interval} --num_splits ~{num_threads}`
            for interval in $intervals
                do
                    echo "variant ~{input_bam} -m ~{max_coverage} -k ${interval} -v -b -o variant_bam/${interval}.bam" >> variant_commands.txt
                done
            parallel --jobs ~{num_threads} < variant_commands.txt
            sambamba merge -t ~{num_threads} output.bam variant_bam/*bam
        fi
        samtools index output.bam
    }

    output{
        File output_bam = 'output.bam'
        File output_bai = 'output.bam.bai'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: "~{num_threads}"
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
