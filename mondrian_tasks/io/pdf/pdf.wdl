version 1.0



task MergePdf{
    input{
        Array[File] infiles
        String filename_prefix
        String? singularity_image
        String? docker_image

    }
    command<<<
        pdf_utils merge_pdfs --infiles ~{sep=" "infiles} --outfile ~{filename_prefix}.pdf
    >>>
    output{
        File merged = '~{filename_prefix}.pdf'
    }
    runtime{
        memory: "8 GB"
        cpu: 1
        walltime: "6:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}