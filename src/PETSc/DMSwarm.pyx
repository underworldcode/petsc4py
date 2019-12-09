# --------------------------------------------------------------------

class DMSwarmType(object):

    BASIC = DMSWARM_BASIC
    PIC = DMSWARM_PIC

class DMSwarmMigrateType(object):

    MIGRATE_BASIC = DMSWARM_MIGRATE_BASIC
    MIGRATE_DMCELLNSCATTER = DMSWARM_MIGRATE_DMCELLNSCATTER
    MIGRATE_DMCELLEXACT = DMSWARM_MIGRATE_DMCELLEXACT
    MIGRATE_USER = DMSWARM_MIGRATE_USER

class DMSwarmCollectType(object):

    COLLECT_BASIC = DMSWARM_COLLECT_BASIC
    COLLECT_DMDABOUNDINGBOX = DMSWARM_COLLECT_DMDABOUNDINGBOX
    COLLECT_GENERAL = DMSWARM_COLLECT_GENERAL
    COLLECT_USER = DMSWARM_COLLECT_USER

class DMSwarmPICLayoutType(object):

    LAYOUT_REGULAR = DMSWARMPIC_LAYOUT_REGULAR
    LAYOUT_GAUSS = DMSWARMPIC_LAYOUT_GAUSS
    LAYOUT_SUBDIVISION = DMSWARMPIC_LAYOUT_SUBDIVISION


cdef class DMSwarm(DM):

    Type = DMSwarmType
    MigrateType = DMSwarmMigrateType
    CollectType = DMSwarmCollectType
    PICLayoutType = DMSwarmPICLayoutType

    def create(self, comm=None):
        cdef MPI_Comm ccomm = def_Comm(comm, PETSC_COMM_DEFAULT)
        cdef PetscDM newdm = NULL
        CHKERR( DMCreate(ccomm, &newdm) )
        PetscCLEAR(self.obj); self.dm = newdm
        DM.setType(self, "swarm")
        return self

    def createGlobalVectorFromField(self, fieldname):
        cdef const_char *cfieldname = NULL
        cdef Vec vg = Vec()
        fieldname = str2bytes(fieldname, &cfieldname)
        CHKERR( DMSwarmCreateGlobalVectorFromField(self.dm, cfieldname, &vg.vec) )
        return vg

    def destroyGlobalVectorFromField(self, fieldname):
        cdef const_char *cfieldname = NULL
        cdef PetscVec vec = NULL
        fieldname = str2bytes(fieldname, &cfieldname)
        CHKERR( DMSwarmDestroyGlobalVectorFromField(self.dm, cfieldname, &vec) )

    def createLocalVectorFromField(self, fieldname):
        cdef const_char *cfieldname = NULL
        cdef Vec vl = Vec()
        fieldname = str2bytes(fieldname, &cfieldname)
        CHKERR( DMSwarmCreateLocalVectorFromField(self.dm, cfieldname, &vl.vec) )
        return vl

    def destroyLocalVectorFromField(self, fieldname):
        cdef const_char *cfieldname = NULL
        cdef PetscVec vec
        fieldname = str2bytes(fieldname, &cfieldname)
        CHKERR( DMSwarmDestroyLocalVectorFromField(self.dm, cfieldname, &vec) )

    def initializeFieldRegister(self):
        CHKERR( DMSwarmInitializeFieldRegister(self.dm) )

    def finalizeFieldRegister(self):
        CHKERR( DMSwarmFinalizeFieldRegister(self.dm) )

    def setLocalSizes(self, nlocal, buffer):
        cdef PetscInt cnlocal = asInt(nlocal)
        cdef PetscInt cbuffer = asInt(buffer)
        CHKERR( DMSwarmSetLocalSizes(self.dm, cnlocal, cbuffer) )
        return self

    def registerPetscDataTypeField(self, fieldname, blocksize, type):
        cdef const_char *cfieldname = NULL
        cdef PetscDataType ctype = <PetscDataType> type
        cdef PetscInt cblocksize = asInt(blocksize)
        fieldname = str2bytes(fieldname, &cfieldname)
        CHKERR( DMSwarmRegisterPetscDatatypeField(self.dm, cfieldname, cblocksize, ctype) )

    def getField(self, fieldname):
        cdef const_char *cfieldname = NULL
        cdef PetscInt blocksize
        cdef PetscDataType ctype
        cdef PetscReal *data
        fieldname = str2bytes(fieldname, &cfieldname)
        CHKERR( DMSwarmGetField(self.dm, cfieldname, &blocksize, &ctype, <void**> &data) )
        array = array_r(asInt(self.getLocalSize()), data)
        return array

    def restoreField(self, fieldname):
        cdef const_char *cfieldname = NULL
        cdef PetscInt blocksize
        cdef PetscDataType ctype
        fieldname = str2bytes(fieldname, &cfieldname)
        CHKERR( DMSwarmRestoreField(self.dm, cfieldname, &blocksize, &ctype, <void**> 0) )

    def vectorDefineField(self, fieldname):
        cdef const_char *cval = NULL
        fieldname = str2bytes(fieldname, &cval)
        CHKERR( DMSwarmVectorDefineField(self.dm, cval) )

    def addPoint(self):
        CHKERR( DMSwarmAddPoint(self.dm) )

    def addNPoints(self, npoints):
        cdef PetscInt cnpoints = asInt(npoints) 
        CHKERR( DMSwarmAddNPoints(self.dm, cnpoints) )

    def removePoint(self):
        CHKERR( DMSwarmRemovePoint(self.dm) )

    def removePointAtIndex(self, index):
        cdef PetscInt cindex = asInt(index)
        CHKERR( DMSwarmRemovePointAtIndex(self.dm, cindex) )

    def copyPoint(self, pi, pj):
        cdef PetscInt cpi = asInt(pi)
        cdef PetscInt cpj = asInt(pj)
        CHKERR( DMSwarmCopyPoint(self.dm, cpi, cpj) )

    def getLocalSize(self):
        cdef PetscInt size = 0
        CHKERR( DMSwarmGetLocalSize(self.dm, &size) )
        return toInt(size)

    def getSize(self):
        cdef PetscInt size = 0
        CHKERR( DMSwarmGetSize(self.dm, &size) )
        return toInt(size)

    def migrate(self, remove_sent_points=False):
        cdef PetscBool remove_pts = asBool(False)
        if remove_sent_points:
            remove_pts = asBool(True)
        CHKERR( DMSwarmMigrate(self.dm, remove_pts) )

    def collectViewCreate(self):
        CHKERR( DMSwarmCollectViewCreate(self.dm) )

    def collectViewDestroy(self):
        CHKERR( DMSwarmCollectViewDestroy(self.dm) )

    def setCellDM(self, DMSwarm dm):
        CHKERR( DMSwarmSetCellDM(self.dm, dm.dm) )
        
    # To Check
    def getCellDM(self):
        cdef DMSwarm dmswarm = DMSwarm() 
        CHKERR( DMSwarmGetCellDM(self.dm, &dmswarm.dm) )
        return dmswarm

    def setType(self, dmswarm_type):
        cdef PetscDMSwarmType cdmswarm_type = dmswarm_type
        CHKERR( DMSwarmSetType(self.dm, cdmswarm_type) )

    def setPointsUniformCoordinates(self, min, max, npoints, mode=None):
        cdef PetscInt dim = 0
        CHKERR( DMGetDimension(self.dm, &dim) )
        cdef PetscReal cmin[3]
        cmin[0] = cmin[1] = cmin[2] = 0
        for i from 0 <= i < dim: cmin[i] = min[i]
        cdef PetscReal cmax[3]
        cmax[0] = cmax[1] = cmax[2] = 0
        for i from 0 <= i < dim: cmax[i] = max[i]
        cdef PetscInt cnpoints[3]
        cnpoints[0] = cnpoints[1] = cnpoints[2] = 0
        for i from 0 <= i < dim: cnpoints[i] = npoints[i]
        cdef PetscInsertMode cmode = insertmode(mode) 
        CHKERR( DMSwarmSetPointsUniformCoordinates(self.dm, cmin, cmax, cnpoints, cmode) )
        return self

    def setPointCoordinates(self, coordinates, redundant=False, mode=None):
        cdef ndarray xyz = iarray(coordinates, NPY_PETSC_REAL)
        if PyArray_ISFORTRAN(xyz): xyz = PyArray_Copy(xyz)
        if PyArray_NDIM(xyz) != 2: raise ValueError(
            ("coordinates must have two dimensions: "
             "coordinates.ndim=%d") % (PyArray_NDIM(xyz)) )
        cdef PetscInt cnpoints = <PetscInt> PyArray_DIM(xyz, 0)
        cdef PetscBool credundant = asBool(redundant)
        cdef PetscInsertMode cmode = insertmode(mode) 
        cdef PetscReal *coords = <PetscReal*> PyArray_DATA(xyz)
        CHKERR( DMSwarmSetPointCoordinates(self.dm, cnpoints, coords, credundant, cmode) )

    def insertPointUsingCellDM(self, layoutType, fill_param):
        cdef PetscDMSwarmPICLayoutType clayoutType = layoutType
        cdef PetscInt cfill_param = asInt(fill_param)
        CHKERR( DMSwarmInsertPointsUsingCellDM(self.dm, clayoutType, cfill_param) )

    def setPointCoordinatesCellwise(self, coordinates):
        cdef ndarray xyz = iarray(coordinates, NPY_PETSC_REAL)
        if PyArray_ISFORTRAN(xyz): xyz = PyArray_Copy(xyz)
        if PyArray_NDIM(xyz) != 2: raise ValueError(
            ("coordinates must have two dimensions: "
             "coordinates.ndim=%d") % (PyArray_NDIM(xyz)) )
        cdef PetscInt cnpoints = <PetscInt> PyArray_DIM(xyz, 0)
        cdef PetscReal *coords = <PetscReal*> PyArray_DATA(xyz)
        CHKERR( DMSwarmSetPointCoordinatesCellwise(self.dm, cnpoints, coords) )

    def viewFieldsXDMF(self, filename, fieldnames):
        cdef const_char *cval = NULL
        cdef const_char *cfilename = NULL
        filename = str2bytes(filename, &cfilename)
        cdef PetscInt cnfields = asInt(len(fieldnames))
        cdef const char** cfieldnames = NULL
        for i from 0 <= i < cnfields:
            fieldname = str2bytes(fieldname, &cval)
            cfieldnames[i] = cval
        CHKERR( DMSwarmViewFieldsXDMF(self.dm, cfilename, cnfields, cfieldnames ) )

    def viewXDMF(self, filename):
        cdef const_char *cval = NULL
        filename = str2bytes(filename, &cval)
        CHKERR( DMSwarmViewXDMF(self.dm, cval) )

    def sortGetAccess(self):
        CHKERR( DMSwarmSortGetAccess(self.dm) )

    def sortRestoreAccess(self):
        CHKERR( DMSwarmSortRestoreAccess(self.dm) )

    def sortGetPointsPerCell(self, e):
        cdef PetscInt ce = asInt(e)
        cdef PetscInt cnpoints
        cdef PetscInt *cpidlist
        cdef list pidlist = []
        CHKERR( DMSwarmSortGetPointsPerCell(self.dm, ce, &cnpoints, &cpidlist) )
        npoints = asInt(cnpoints)
        for i from 0 <= i < npoints: pidlist.append(asInt(cpidlist[i]))
        return pidlist

    def sortGetNumberOfPointsPerCell(self, e):
        cdef PetscInt ce = asInt(e)
        cdef PetscInt npoints
        CHKERR( DMSwarmSortGetNumberOfPointsPerCell(self.dm, ce, &npoints) )
        return toInt(npoints)

    def sortGetIsValid(self):
        cdef PetscBool isValid 
        CHKERR( DMSwarmSortGetIsValid(self.dm, &isValid) )
        return toBool(isValid)

    def sortGetSizes(self):
        cdef PetscInt ncells
        cdef PetscInt npoints
        CHKERR( DMSwarmSortGetSizes(self.dm, &ncells, &npoints) )
        return (toInt(ncells), toInt(npoints))

    def projectFields(self, fieldnames, reuse=False):
        cdef PetscBool creuse = asBool(reuse)
        cdef const_char *cval = NULL
        cdef PetscInt cnfields = asInt(len(fieldnames))
        cdef const char** cfieldnames = NULL
        cdef PetscVec *cfieldvecs
        for i from 0 <= i < cnfields:
            fieldname = str2bytes(fieldname, &cval)
            cfieldnames[i] = cval
        CHKERR( DMSwarmProjectFields(self.dm, cnfields, cfieldnames, &cfieldvecs, creuse) ) 
        cdef list fieldvecs = []
        for i from 0 <= i < cnfields:
            newVec = Vec()
            newVec.vec = cfieldvecs[i]
            fieldvecs.append(newVec)
        return fieldvecs


del DMSwarmType
del DMSwarmMigrateType
del DMSwarmCollectType
del DMSwarmPICLayoutType
