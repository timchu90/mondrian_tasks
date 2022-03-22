version 1.0


task RunMuseq{
    input{
        File normal_bam
        File normal_bai
        File tumour_bam
        File tumour_bai
        Int max_coverage=10000
        File reference
        File reference_fai
        String interval
        String? singularity_image
        String? docker_image
        Int? num_threads = 1
        Int? memory_gb = 12
        Int? walltime_hours = 96
    }
    command<<<
        mkdir tumour_variant_bam normal_variant_bam pythonegg museq_vcf museq_log
        export PYTHON_EGG_CACHE=$PWD/pythonegg
        intervals=`variant_utils split_interval --interval ~{interval} --num_splits ~{num_threads}`
        echo $intervals


        if [[ ~{num_threads} -eq 1 ]]
        then
            variant ~{normal_bam} -m ~{max_coverage} -k ~{interval} -v -b -o normal.bam
            variant ~{tumour_bam} -m ~{max_coverage} -k ~{interval} -v -b -o tumour.bam
            samtools index normal.bam
            samtools index tumour.bam
        else
            mkdir tumour_variant_bam normal_variant_bam
            for interval in $intervals
                do
                    echo "variant ~{normal_bam} -m ~{max_coverage} -k ${interval} -v -b -o normal_variant_bam/${interval}.bam" >> variant_commands.txt
                    echo "variant ~{tumour_bam} -m ~{max_coverage} -k ${interval} -v -b -o tumour_variant_bam/${interval}.bam" >> variant_commands.txt
                done
            parallel --jobs ~{num_threads} < variant_commands.txt

            sambamba merge -t ~{num_threads} normal.bam normal_variant_bam/*bam
            sambamba merge -t ~{num_threads} tumour.bam tumour_variant_bam/*bam
            samtools index normal.bam
            samtools index tumour.bam
        fi

        for interval in $intervals
            do
                echo "museq normal:normal.bam tumour:tumour.bam reference:~{reference} \
                --out museq_vcf/${interval}.vcf --log museq_log/${interval}.log -v -i ${interval} ">> museq_commands.txt
            done
        parallel --jobs ~{num_threads} < museq_commands.txt


        variant_utils merge_vcf_files --inputs museq_vcf/*vcf --output merged.vcf
        variant_utils fix_museq_vcf --input merged.vcf --output merged.fixed.vcf
        vcf-sort merged.fixed.vcf > merged.sorted.fixed.vcf
        bgzip merged.sorted.fixed.vcf -c > merged.sorted.fixed.vcf.gz
        bcftools index merged.sorted.fixed.vcf.gz
        tabix -f -p vcf merged.sorted.fixed.vcf.gz
    >>>

    output{
        File vcf = 'merged.sorted.fixed.vcf.gz'
        File vcf_csi = 'merged.sorted.fixed.vcf.gz.csi'
        File vcf_tbi = 'merged.sorted.fixed.vcf.gz.tbi'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: "~{num_threads}"
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}


task FixMuseqVcf{
    input{
        File vcf_file
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8

    }
    command<<<
        variant_utils fix_museq_vcf --input ~{vcf_file} --output output.vcf
        bgzip output.vcf -c > output.vcf.gz
        bcftools index output.vcf.gz
        tabix -f -p vcf output.vcf.gz
    >>>
    output{
        File output_vcf = 'output.vcf.gz'
        File output_csi = 'output.vcf.gz.csi'
        File output_tbi = 'output.vcf.gz.tbi'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}
