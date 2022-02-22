version 1.0



task MergePdf{
    input{
        Array[File] infiles
        String filename_prefix
        String? singularity_image
        String? docker_image
        Int? memory_gb = 8
        Int? walltime_hours = 8
    }
    command<<<
        pdf_utils merge_pdfs --infiles ~{sep=" "infiles} --outfile ~{filename_prefix}.pdf
    >>>
    output{
        File merged = '~{filename_prefix}.pdf'
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}