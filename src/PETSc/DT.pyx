
class QuadType(object):
    pass

class QuadOption(object):
    pass


cdef class Quad(Object):

    Type = QuadType
    Option = QuadOption

    def __cinit__(self):
        self.obj = <PetscObject*> &self.quad
        self.quad = NULL

del QuadType
del QuadOption
