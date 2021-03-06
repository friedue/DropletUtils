\name{write10xCounts}
\alias{write10xCounts}

\title{Write count data in the 10x format}
\description{
Create a directory containing the count matrix and cell/gene annotation from a sparse matrix of UMI counts, in the format produced by the CellRanger software suite.}

\usage{
write10xCounts(path, x, barcodes=colnames(x), gene.id=rownames(x),
    gene.symbol=gene.id, gene.type="Gene Expression", overwrite=FALSE, 
    type=c("auto", "sparse", "HDF5"), genome="unknown", version=c("2", "3"))
}

\arguments{
\item{x}{A sparse numeric matrix of UMI counts.}
\item{path}{A string containing the path to the output directory.}
\item{barcodes}{A character vector of cell barcodes, one per column of \code{x}.}
\item{gene.id}{A character vector of gene identifiers, one per row of \code{x}.}
\item{gene.symbol}{A character vector of gene symbols, one per row of \code{x}.}
\item{gene.type}{A character vector of gene types, expanded to one per row of \code{x}.
Only used when \code{version="3"}.}
\item{overwrite}{A logical scalar specifying whether \code{path} should be overwritten if it already exists.}
\item{type}{String specifying the type of 10X format to save \code{x} to.}
\item{genome}{String specifying the genome for storage when \code{type="HDF5"}.
This can be a character vector with one genome per feature if \code{version="3"}.}
\item{version}{String specifying the version of the CellRanger format to produce.}
}

\details{
This function will try to automatically detect the desired format based on whether \code{path} ends with \code{".h5"}.
If so, it assumes that \code{path} specifies a HDF5 file path and sets \code{type="HDF5"}.
Otherwise it will set \code{type="sparse"} under the assumption that \code{path} specifies a path to a directory.

Note that there were major changes in the output format for CellRanger version 3.0, to account for non-gene features such as antibody or CRISPR tags. 
Users can switch to this new format using \code{version="3"}.
See the documentation for \dQuote{latest} for this new format, otherwise see \dQuote{2.2} or earlier.
}

\value{
For \code{type="sparse"}, a directory is produced at \code{path}.
If \code{version="2"}, this will contain the files \code{"matrix.mtx"}, \code{"barcodes.tsv"} and \code{"genes.tsv"}.
If \code{version="3"}, it will instead contain \code{"matrix.mtx.gz"}, \code{"barcodes.tsv.gz"} and \code{"features.tsv.gz"}.

For \code{type="HDF5"}, a HDF5 file is produced at \code{path} containing data in column-sparse format.
If \code{version="2"}, data are stored in the HDF5 group named \code{genome}.
If \code{version="3"}, data are stored in the group \code{"matrix"}.

A \code{TRUE} value is invisibly returned.
}

\author{
Aaron Lun
}

\seealso{
\code{\link{read10xCounts}}
}

\examples{
# Mocking up some count data.
library(Matrix)
my.counts <- matrix(rpois(1000, lambda=5), ncol=10, nrow=100)
my.counts <- as(my.counts, "dgCMatrix")
cell.ids <- paste0("BARCODE-", seq_len(ncol(my.counts)))

ngenes <- nrow(my.counts)
gene.ids <- paste0("ENSG0000", seq_len(ngenes))
gene.symb <- paste0("GENE", seq_len(ngenes))

# Writing this to file:
tmpdir <- tempfile()
write10xCounts(tmpdir, my.counts, gene.id=gene.ids, 
    gene.symbol=gene.symb, barcodes=cell.ids)
list.files(tmpdir)
}

\references{
10X Genomics (2017).
Gene-Barcode Matrices.
\url{https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/2.2/output/matrices}

10X Genomics (2018).
Feature-Barcode Matrices.
\url{https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/output/matrices}

10X Genomics (2018).
HDF5 Gene-Barcode Matrix Format.
\url{https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/2.2/advanced/h5_matrices}

10X Genomics (2018).
HDF5 Feature Barcode Matrix Format.
\url{https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/advanced/h5_matrices}
}
