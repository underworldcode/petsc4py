# --------------------------------------------------------------------

cdef extern from * nogil:
  
    ctypedef char* PetscFEType "const char*"
    PetscFEType PETSCFEBASIC
    PetscFEType PETSCFEOPENCL
    PetscFEType PETSCFECOMPOSITE

    int PetscFECreateDefault(MPI_Comm, PetscInt, PetscInt, PetscBool, const char [], PetscInt, PetscFE*) 
    int PetscFESetType(PetscFE, PetscFEType)
    int PetscFEGetQuadrature(PetscFE, PetscQuadrature*)
    int PetscFEGetFaceQuadrature(PetscFE, PetscQuadrature*)
    int PetscFESetQuadrature(PetscFE, PetscQuadrature)
    int PetscFESetFaceQuadrature(PetscFE, PetscQuadrature)
    int PetscFEDestroy(PetscFE*)
    
